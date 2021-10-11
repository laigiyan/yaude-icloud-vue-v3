<template>
  <a-modal
    :title="title"
    :width="800"
    :visible="visible"
    :confirmLoading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
    cancelText="关闭">
    <a-spin :spinning="confirmLoading">
      <a-form-model ref="form"  :label-col="labelCol" :wrapper-col="wrapperCol"  :model="model" :rules="validatorRules">
        <a-form-model-item label="卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="inUseVolumeId" >
          <a-select v-model="model.inUseVolumeId"  placeholder="请选择卷">
            <a-select-option v-for="volume in inUseVolumes":value="volume.value"  >{{volume.text}}</a-select-option>
          </a-select>

        </a-form-model-item>

        <a-form-model-item label="説明"  hasFeedback>
          <span>从正在运行的实例上分离卷</span>
        </a-form-model-item>

      </a-form-model>
    </a-spin>
  </a-modal>
</template>

<script>
  import { getAction,httpAction } from '@/api/manage'

  export default {
    name: "OsAvailableVolume",
    data () {
      return {
        title:"分離卷",
        visible: false,
        model: {},
        layout: {
          labelCol: { span: 3 },
          wrapperCol: { span: 14 },
        },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 3 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        form: this.$form.createForm(this),
        validatorRules:{
          inUseVolumeId: [
            { required: true, message: '请选择卷!' },
          ],
        },
        url: {
          getInUseVolumes:"/openstack/osInstance/getInUseVolumes",
          detachVolume:"/openstack/osInstance/detachVolume"
        },
        inUseVolumes:[]
      }
    },
    created () {

    },
    methods: {
      add () {
        this.edit({});
      },
      edit (record) {
        this.getInUseVolumes(record);
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      close () {
        this.$refs.form.resetFields();
        this.$emit('close');
        this.visible = false;
      },
      handleOk () {
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            getAction(this.url.detachVolume,this.model).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
              that.close();
            })
          }
        })
      },
      handleCancel () {
        this.close()
      },
      //获取可以连接的卷
      getInUseVolumes(record){
        getAction(this.url.getInUseVolumes,record).then((res)=>{
          if(res.success){
            this.inUseVolumes = [];
            res.result.forEach((r)=>{
              let name = r.name;
              if(name>''){
                name = '('+r.name+')';
              }
              this.inUseVolumes.push({
                value:r.id,
                text: name+r.id,
              })
            })
          }
        })
      },
    }
  }
</script>

<style scoped>

</style>