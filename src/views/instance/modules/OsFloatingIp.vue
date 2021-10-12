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
        <a-form-model-item label="浮動IP" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="floatingIpId" >
          <a-select v-model="model.floatingIpId"  placeholder="请选择浮動IP">
            <a-select-option v-for="fl in floatingIps":value="fl.value"  >{{fl.text}}</a-select-option>
          </a-select>

        </a-form-model-item>

        <a-form-model-item label="説明"  hasFeedback>
          <span>请为选中的实例选择要绑定的IP地址。</span>
        </a-form-model-item>

      </a-form-model>
    </a-spin>
  </a-modal>
</template>

<script>
  import { getAction,httpAction } from '@/api/manage'

  export default {
    name: "OsFloatingIp",
    data () {
      return {
        title:"綁定浮動IP",
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
          floatingIpId: [
            { required: true, message: '請選擇浮動IP!' },
          ],
        },
        url: {
          getFloatingIps:"/openstack/osInstance/getFloatingIps",
          addFloatingIp:"/openstack/osInstance/addFloatingIp"
        },
        floatingIps:[]
      }
    },
    created () {

    },
    methods: {
      add () {
        this.edit({});
      },
      edit (record) {
        this.getFloatingIps(record);
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
            getAction(this.url.addFloatingIp,this.model).then((res)=>{
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
      //获取浮动IP
      getFloatingIps(record){
        getAction(this.url.getFloatingIps,record).then((res)=>{
          if(res.success){
            this.floatingIps = [];
            res.result.forEach((r)=>{
              this.floatingIps.push({
                value:r.floating_ip_address,
                text: r.floating_ip_address,
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