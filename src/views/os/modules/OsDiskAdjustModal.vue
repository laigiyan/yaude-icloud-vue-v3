<template>
  <a-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="关闭">
    <a-form ref="form" :model="model" >
      <a-row>
        <a-col :span="24">
          <a-form-model-item label="名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="diskName">
            <a-input v-model="model.diskName" placeholder="请输入名称"  :disabled="true"></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
            <a-input v-model="model.represent" placeholder="请输入描述" :disabled="true" ></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="大小" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="size">
            <a-input v-model="model.size" placeholder="请输入大小"  ></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="类型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="type">
            <a-select v-model="model.type"  placeholder="请选择类型" >
              <a-select-option v-for="type in types":value="type.value" >{{type.text}}</a-select-option>
            </a-select>

          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="来源" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="source">
            <j-dict-select-tag type="list" v-model="model.source" dictCode="disk_source" placeholder="请选择来源"  />
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="是否加密" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="bootable">
            <j-dict-select-tag type="list" v-model="model.bootable" dictCode="bootable" placeholder="请选择是否加密" />
          </a-form-model-item>
        </a-col>
      </a-row>
    </a-form>
  </a-modal>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  export default {
    name: 'OsDiskAdjustModal',
    components: {
    },

    data () {
      return {
        model:{
        },
        form: this.$form.createForm(this),
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {

        },

        url: {
          adjust: "/os/osApplyDisk/adjust",
          getType: "/os/osApplyDisk/getType"
        },
        types:[]
      }
    },
    created () {
      this.getType(this.model);
    },
    methods: {
      adjust (record) {
        this.form.resetFields();
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      handleOk () {
        let that = this;
        let method = 'post';
        let httpurl=this.url.adjust;
        let formData={
          diskName: this.model.diskName,
          options: "2",
          represent: this.model.represent,
          size: this.model.size,
          type: this.model.type,
          source: this.model.source,
          boostatus: "1",
          bootable: this.model.bootable,
        }
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.loadData();
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
          that.close();
        })
      },

      getType(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getType;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.types.push({
                value:r.type,
                text:r.type
              })
            })
          }
        })
      },
      close () {
        this.$emit('close');
        this.visible = false;
      },


      submitCallback(){
        this.$emit('ok');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      }
    }
  }
</script>