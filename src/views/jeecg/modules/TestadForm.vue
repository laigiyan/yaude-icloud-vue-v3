<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="编号" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="num">
              <a-input-number v-model="model.num" placeholder="请输入编号" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="文本" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="text">
              <a-input v-model="model.text" placeholder="请输入文本"  ></a-input>
              <a-button @click="handleTranslate"  type="primary" icon="">多语言</a-button>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
      <sys-translate-modal ref="modalForm" @ok="modalFormOk"></sys-translate-modal>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'
  import SysTranslateModal from '../../system/modules/SysTranslateModal'


  export default {
    name: 'TestadForm',
    components: {
      SysTranslateModal
    },
    props: {
      //表单禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
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
           num: [
              { required: true, message: '请输入编号!'},
           ],
        },
        url: {
          add: "/test/testad/add",
          edit: "/test/testad/edit",
          queryById: "/test/testad/queryById"
        }
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //备份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      submitForm () {
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
      handleTranslate(){
        var params = {
          relateTable: 'testad',
          relateId:this.model.id,
          chinese:this.model.text
        }
        getAction("/system/sysTranslate/queryByParams", params).then((res) => {
          if (res.success) {
            this.$refs.modalForm.edit(res.result);
            this.$refs.modalForm.title = "修改多语言配置";
          }
          else {
            this.$refs.modalForm.edit(params);
            this.$refs.modalForm.title = "新增多语言配置";
          }
        })
      },
      modalFormOk(){

      }
    }
  }
</script>